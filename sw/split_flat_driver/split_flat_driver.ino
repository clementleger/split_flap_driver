//#define HAVE_WIFI

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <Arduino.h>
#include <Wire.h>
#include <SPI.h>
#include "c_types.h"
#ifdef HAVE_WIFI
#include "wifi_params.h"
#endif

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
#define PCF8574_BASE_ADDR	0x20
#define SPI_FREQUENCY	1000000
#define SPI_SR_CS	D8

/* Shared interrupt */
#define INPUT_EXP_INT	D3
#define INPUT_EXP1_ADDR	(PCF8574_BASE_ADDR)

#define STEP_DELAY_US	2000
#define NUM_COILS	4
#define MAX_CHARS	64

#define PCF8574_INPUT_COUNT	8

#define STEPS_PER_REV		2038
#define STEPS_PER_LETTER	(STEPS_PER_REV / ARRAY_SIZE(flaps_chars))

#define SPLITFLAP_DNS_NAME	"splitflap"

enum display_state {
	DISPLAY_IDLE,
	DISPLAY_SYNCING,
	DISPLAY_UPDATING,
	DISPLAY_SERIAL_RECV,
};

static const char flaps_chars[] =
{
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
	'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'1', '2', '3', '4', '5', '6', '7', '8', '9',
	'#', ',', ':', '*', ' '
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
	u8 start_adjust_steps;
};


static struct split_flat_con split_flaps[] = {
	{{3, 2, 1, 0}, 0, 0, ' ', 'b', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	{{4, 5, 6, 7}, 1, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{8, 9, 10, 11}, 2, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{12, 13, 14, 15}, 3, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{16, 17, 18, 19}, 4, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{20, 21, 22, 23}, 5, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{24, 25, 26, 27}, 6, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
	//~ {{28, 29, 30, 31}, 7, 0, ' ', ' ', ' ', CHARS_COUNT, flaps_chars, 0, 0},
};

//~ #define SPLIT_FLAP_COUNT ARRAY_SIZE(split_flaps)
#define SPLIT_FLAP_COUNT 1
#define SPLIT_FLAT_MASK		((1 << SPLIT_FLAP_COUNT) - 1)

/* Bitmask which will */
static u8 shift_register_buffer[ARRAY_SIZE(split_flaps) / 2] = {0};

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
static unsigned short step_delay_us = STEP_DELAY_US;

static int display_state = DISPLAY_IDLE;
String display_str;

static void display_set_state(int state)
{
	Serial.print("settings display state to ");
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

	display_set_state(DISPLAY_SYNCING);
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
	if (str_arg.length() > SPLIT_FLAP_COUNT) {
		server.send(400, "text/plain", "Maximum string size exceeded");
		return;
	}

	display_str = str_arg;
	display_set_state(DISPLAY_UPDATING);

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
#define SERIAL_COMMAND_LEN	64
static char serial_command[SERIAL_COMMAND_LEN + 1] = {0};
static byte serial_command_idx = 0;

static int serial_read_chars()
{
	while(Serial.available() > 0) {
		serial_command[serial_command_idx] = Serial.read();
		if (serial_command[serial_command_idx] == '\n') {
			serial_command[serial_command_idx] = '\0';
			serial_command_idx = 0;
			return 1;
		}
		serial_command_idx++;
		if (serial_command_idx > SERIAL_COMMAND_LEN) {
			Serial.println("String too long !");
			serial_command_idx = 0;
		}
	}

	return 0;
}

static void serial_parse_command()
{
	char *n;
	int flap, steps;

	if (strcmp(serial_command, "sync") == 0) {
		display_set_state(DISPLAY_SYNCING);
	} else if (strncmp(serial_command, "disp", strlen("disp")) == 0) {
		n = strchr(serial_command, ';');
		n++;
		disp_string(n);
	}else if (strncmp(serial_command, "speed", strlen("speed")) == 0) {
		n = strchr(serial_command, ';');
		n++;
		step_delay_us = atoi(n);
		Serial.print("Setting speed to ");
		Serial.println(step_delay_us);
	} else if (strncmp(serial_command, "step", strlen("step")) == 0) {
		n = strchr(serial_command, ';');
		if (!n)
			Serial.println("step;flap;count");
		n++;
		flap = atoi(n);
		n = strchr(serial_command, ';');
		if (!n)
			Serial.println("step;flap;count");
		n++;
		steps = atoi(n);
	} else {
		Serial.print("Invalid command: ");
		Serial.println(serial_command);
	}
}

static void serial_state_step()
{
	int ret;

	ret = serial_read_chars();
	if (ret)
		serial_parse_command();
	
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

	Serial.print("Distance between ");
	Serial.print(current);
	Serial.print(" and ");
	Serial.print(target);
	Serial.print(": ");
	
	/* We need to wrap so we will sync */
	if (target_offset < cur_offset) {
		steps = (target_offset + CHARS_COUNT) - cur_offset;
	} else {
		steps = (target_offset - cur_offset);
	}
	Serial.println(steps);

	return steps * STEPS_PER_LETTER;
}

static u64 pcf_input_status = 0;

static uint8_t read_pcf(struct pcf_input *pcf)
{
	uint8_t status;

	Wire.requestFrom(pcf->addr, (uint8_t) 1);
	while (Wire.available() < 1);

	status = Wire.read();

	return status;
}

static void check_input_status(void)
{
	uint8_t status;

	for (uint8_t i = 0; i < ARRAY_SIZE(pcf_inputs); i++) {
		struct pcf_input *pcf = &pcf_inputs[i];

		/* Interrupt is a NOT */
		if (digitalRead(pcf->pin) == HIGH)
			continue;

		status = read_pcf(pcf);

		/* Logic is inverted, ie gnd when triggered */
		pcf_input_status |= (~status << (i * PCF8574_INPUT_COUNT));
	}
}

static void reset_input_status()
{
	pcf_input_status = 0;
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

	/* Latch data */
	digitalWrite(SPI_SR_CS, LOW);
	digitalWrite(SPI_SR_CS, HIGH);
	digitalWrite(SPI_SR_CS, LOW);

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
	int next_coil = flap->cur_coil + 1;

	if (next_coil > NUM_COILS)
		next_coil = 0;

	/* Full step drive */
	shift_reg_set_bit(flap->motor_coils_shift[cur_coil]);
	shift_reg_set_bit(flap->motor_coils_shift[next_coil]);

	cur_coil++;
	if (cur_coil >= NUM_COILS)
		cur_coil = 0;

	flap->cur_coil = cur_coil;
}

static unsigned int update_flaps_last_micros = 0;

static void sync_all_flaps_step(void)
{
	unsigned int cur_micros = micros(); 
	if (cur_micros - update_flaps_last_micros < step_delay_us)
		return;

	update_flaps_last_micros = cur_micros;
	for (uint8_t i = 0; i < SPLIT_FLAP_COUNT; i++) {
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
	for (uint8_t i = 0; i < SPLIT_FLAP_COUNT; i++) {
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

void display_sync_step()
{
	check_input_status();
	if (all_flaps_synced()) {
		Serial.println("All flaps synced !");

		/* Syncing done ! */
		reset_input_status();
		display_set_state(DISPLAY_IDLE);
		reset_flaps_start_character();
	} else {
		sync_all_flaps_step();
	}
}


void display_update_step()
{
	bool target_reached = true;
	unsigned int cur_micros = micros(); 
	if (cur_micros - update_flaps_last_micros < step_delay_us)
		return;

	update_flaps_last_micros = cur_micros;
	for (uint8_t i = 0; i < SPLIT_FLAP_COUNT; i++) {
		struct split_flat_con *flap = &split_flaps[i];

		if (flap->steps_to_do--) {
			target_reached = false;
			do_flap_motor_step(flap);
			flap->current_char = flap->target_char;
		}
	}

	flaps_update_all();

	if (target_reached)
		display_set_state(DISPLAY_IDLE);
}

static void disp_string(String str)
{
	Serial.print("Displaying text: ");
	Serial.println(str);
	for (uint8_t i = 0; i < SPLIT_FLAP_COUNT; i++) {
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

	display_set_state(DISPLAY_UPDATING);
}

void setup(void)
{
	Serial.begin(115200);

#ifdef HAVE_WIFI
	Serial.println("Connecting...");
	WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

	while(!WiFi.isConnected() ){
		Serial.println("Waiting for connection");
		delay(1000);
	}
	Serial.println("Connected !");
#endif
	Serial.println("Init inputs");

	pinMode(INPUT_EXP_INT, INPUT_PULLUP);

	Wire.begin(D2, D1);
	/* Configure IO expander interrupts pins as input */
	for (uint8_t i = 0; i < ARRAY_SIZE(pcf_inputs); i++) {
		struct pcf_input *in = &pcf_inputs[i];

		/* Set all pins as input */
		Wire.beginTransmission(in->addr);
		Wire.write(0xFF);
		Wire.endTransmission();
	}
	Serial.println("Init SPI");
	
	pinMode(SPI_SR_CS, OUTPUT);
	digitalWrite(SPI_SR_CS, LOW);
	SPI.begin();

	Serial.println("SPI init done");
	/* Release all motors coils */
	flaps_update_all();

	Serial.println("Init inputs");

	sync_reset_flaps();

	server_init();
	
}

void loop(void)
{
	server_update();

	switch (display_state) {
		case DISPLAY_SYNCING:
			display_sync_step();
		break;
		case DISPLAY_UPDATING:
			display_update_step();
		break;
		case DISPLAY_SERIAL_RECV:
			serial_state_step();
		break;
		default:
			if (Serial.available() > 0)
				display_set_state(DISPLAY_SERIAL_RECV);
		break;
	}
}
