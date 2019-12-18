#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

#include <Arduino.h>
#include <Wire.h>
#include <SPI.h>
#include "c_types.h"

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
#define PCF8574_BASE_ADDR	0x20
#define SPI_FREQUENCY	1000000

/* Shared interrupt */
#define INPUT_EXP_INT	D3

#define INPUT_EXP1_ADDR	(PCF8574_BASE_ADDR)

#define STEP_DELAY_US	2000
#define NUM_COILS	4
#define MAX_CHARS	64

#define SPLIT_FLAT_MASK		((1 << ARRAY_SIZE(split_flaps)) - 1)
#define PCF8574_INPUT_COUNT	8

#define STEPS_PER_REV		2038
#define STEPS_PER_LETTER	(STEPS_PER_REV / ARRAY_SIZE(flaps_chars))

#define SPLITFLAP_DNS_NAME	"splitflap"

enum display_state {
	DISPLAY_IDLE,
	DISPLAY_SYNCING,
	DISPLAY_UPDATING,
};

static const char flaps_chars[] =
{
	'1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
	'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'.', ' '
};

#define CHARS_COUNT	ARRAY_SIZE(flaps_chars)

struct split_flat_con {
	u16 motor_coils_shift[NUM_COILS];
	u8 input_shift;
	u8 cur_coil;
	u8 current_char;
	u8 start_char;
	u8 target_char;
	u8 chars_count;
	const char *chars;
	u32 steps_to_do;
};

static struct split_flat_con split_flaps[] = {
	{{0, 1, 2, 3}, 0, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0},
	{{7, 6, 5, 4}, 1, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0},
	{{8, 9, 10, 11}, 2, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0},
	{{12, 13, 14, 15}, 3, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0},
};

/* Bitmask which will */
static u8 shift_register_buffer[ARRAY_SIZE(split_flaps) * 4] = {0};

struct pcf_input {
	int pin;
	uint8_t addr;
	uint8_t width;
};

static struct pcf_input pcf_inputs[] = 
{
	{INPUT_EXP_INT, INPUT_EXP1_ADDR, PCF8574_INPUT_COUNT},
};

ESP8266WebServer server(80);
static void disp_string(String str);

static int display_state = DISPLAY_IDLE;
String display_str;

static void set_state(int state)
{
	Serial.print("settings state to ");
	Serial.println(state);
	display_state = state;
}

/**
 * Server part
 */
 
int server_feed_parts = 0;

static void server_handle_root()
{
	server.send(200, "text/plain", "split-flap is online !");
}

static void server_handle_sync()
{
	if (display_state != DISPLAY_IDLE) {
		server.send(503, "text/plain", "Busy !");
		return;
	}

	set_state(DISPLAY_SYNCING);
	server.send(200, "text/plain", "Busy !");
}

static void server_handle_disp()
{
	if (display_state != DISPLAY_IDLE) {
		server.send(503, "text/plain", "Busy !");
		return;
	}

	if (!server.hasArg("string")) {
		server.send(400, "text/plain", "Missing string parameter");
		return;
	}

	String str_arg = server.arg("string");
	if (str_arg.length() > ARRAY_SIZE(split_flaps)) {
		server.send(400, "text/plain", "Maximum string size exceeded");
		return;
	}

	display_str = str_arg;
	set_state(DISPLAY_UPDATING);

	server.send(200, "text/plain", "Displaying");
}

static void server_handle_not_found()
{
	String message = "File Not Found\n\n";
	server.send(404, "text/plain", message);
}

static void server_init()
{

	if (MDNS.begin(SPLITFLAP_DNS_NAME))
		Serial.println("MDNS responder started");

	server.on("/", server_handle_root);
	server.on("/disp", server_handle_disp);
	server.on("/sync", server_handle_sync);
	server.onNotFound(server_handle_not_found);
	server.begin();
}

static void server_update()
{
	server.handleClient();
	MDNS.update();
}

/**
 * Serial part
 */
static void serial_check()
{
	/* Do not handle serial if we are updating/syncing the display */
	if (display_state != DISPLAY_IDLE)
		return;

	String s = Serial.readStringUntil('\n');
	if (s == "sync") {
		set_state(DISPLAY_UPDATING);
	} else if (s.startsWith("disp")) {
		Serial.println("Enter text: ");
		String text = Serial.readStringUntil('\n');
		disp_string(text);
	} else {
		Serial.print("Invalid command: ");
		Serial.println(s);
	}
}

/**
 * Core part
 */

static int get_letter_offset(char l)
{
	for (uint8_t i = 0; i < ARRAY_SIZE(flaps_chars); i++) {
		if (flaps_chars[i] == l)
			return i;
	}

	return -1;
}

static int get_steps_between_letter(char current, char target)
{
	int cur_offset = get_letter_offset(current);
	int target_offset = get_letter_offset(target);
	int steps;

	/* We need to wrap so we will sync */
	if (target_offset < cur_offset) {
		steps = (target_offset + CHARS_COUNT) - cur_offset;
	} else {
		steps = (target_offset - cur_offset);
	}

	return steps * STEPS_PER_LETTER;
}

static u64 pcf_input_status = 0;

static void check_input_status(void)
{
	uint8_t status;

	for (uint8_t i = 0; i < ARRAY_SIZE(pcf_inputs); i++) {
		/* Interrupt is a NOT */
		if (digitalRead(pcf_inputs[i].pin) == HIGH)
			continue;

		Wire.requestFrom(pcf_inputs[i].addr, (uint8_t) 1);
		while (Wire.available() < 1);

		status = Wire.read();

		/* Logic is inverted, ie gnd when triggered */
		pcf_input_status |= (~status << (i * PCF8574_INPUT_COUNT));
	}
}

SPISettings spi_settings(SPI_FREQUENCY, MSBFIRST, SPI_MODE0);

/**
 * Drive all motor coils according to the next_value.
 */
static void flaps_update_all(void)
{
	SPI.beginTransaction(spi_settings);
	SPI.transfer(shift_register_buffer, ARRAY_SIZE(shift_register_buffer));
	SPI.endTransaction();

	/* Reset buffer */
	memset(shift_register_buffer, 0, ARRAY_SIZE(shift_register_buffer));
}

static void shift_reg_set_bit(u16 bit)
{
	u16 offset = (bit / 8);

	shift_register_buffer[offset] |= (1 << (bit % 8));
}

static int flap_sync_triggered(struct split_flat_con *flap)
{
	return (pcf_input_status & (1 << flap->input_shift));
}

static int all_flaps_synced(void)
{
	return (pcf_input_status & SPLIT_FLAT_MASK) == SPLIT_FLAT_MASK;
}

static void do_flap_motor_step(struct split_flat_con *flap)
{
	int cur_coil = flap->cur_coil;

	shift_reg_set_bit(flap->motor_coils_shift[cur_coil]);

	cur_coil++;
	if (cur_coil >= NUM_COILS)
		cur_coil = 0;

	flap->cur_coil = cur_coil;
}

static unsigned int sync_last_micros = 0;

static void sync_all_flaps_step(void)
{
	unsigned int cur_micros = micros(); 
	if (cur_micros - sync_last_micros < STEP_DELAY_US)
		return;

	sync_last_micros = cur_micros;
	for (uint8_t i = 0; i < ARRAY_SIZE(split_flaps); i++) {
		struct split_flat_con *flap = &split_flaps[i];
		if (flap_sync_triggered(flap))
			continue;

		do_flap_motor_step(flap);
	}

	flaps_update_all();
}

static void reset_flaps_start_character()
{
	Serial.println("Resetting flaps to start_character");

	ESP.wdtFeed();
	for (uint8_t i = 0; i < ARRAY_SIZE(split_flaps); i++) {
		struct split_flat_con *flap = &split_flaps[i];
		flap->current_char = flap->start_char;
	}
}

static void sync_reset_flaps(void)
{
	Serial.println("Resetting all flaps");
	while (!all_flaps_synced()) {
		sync_all_flaps_step();
		check_input_status();
		ESP.wdtFeed();
	}

	reset_flaps_start_character();
}

static void disp_string(String str)
{
	Serial.print("Displaying text: ");
	Serial.println(str);
	for (uint8_t i = 0; i < ARRAY_SIZE(split_flaps); i++) {
		struct split_flat_con *flap = &split_flaps[i];
		if (i < str.length())
			flap->target_char = str.charAt(i);
		else
			flap->target_char = ' ';

		flap->steps_to_do = get_steps_between_letter(flap->current_char,
							     flap->target_char);
		Serial.print("Flaps ");
		Serial.print(i);
		Serial.print(": ");
		Serial.print(flap->steps_to_do);
		Serial.println(" steps");
	}

	set_state(DISPLAY_UPDATING);
}

void setup(void)
{
	Serial.begin(115200);
	Wire.begin(D2, D1);

	Serial.println("Init inputs");
	/* Configure IO expander interrupts pins as input */
	for (uint8_t i = 0; i < ARRAY_SIZE(pcf_inputs); i++) {
		struct pcf_input *in = &pcf_inputs[i];
		pinMode(in->pin, INPUT_PULLUP);

		/* Set all pins has input */
		Wire.beginTransmission(in->addr);
		Wire.write(0xFF);
		Wire.endTransmission();
	}

	SPI.begin();

	sync_reset_flaps();
	disp_string("");

	server_init();
	
}

void loop(void)
{
	server_update();
	serial_check();

	if (display_state == DISPLAY_SYNCING) {
		check_input_status();
		sync_all_flaps_step();
		if (all_flaps_synced()) {
			Serial.println("All flaps synced !");

			/* Syncing done ! */
			set_state(display_state);
			reset_flaps_start_character();
		}
	} else if (display_state == DISPLAY_UPDATING) {
		
		set_state(DISPLAY_IDLE);
	}
}
