#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "structs.h"

#define SMAX 50

void get_operations(void **);

void *TIRE_data_read(FILE *in)
{
	tire_sensor *TIRE = malloc(sizeof(tire_sensor));

	fread(&TIRE->pressure, sizeof(float), 1, in);
	fread(&TIRE->temperature, sizeof(float), 1, in);
	fread(&TIRE->wear_level, sizeof(int), 1, in);
	fread(&TIRE->performace_score, sizeof(int), 1, in);

	return TIRE;
}

void *PMU_data_read(FILE *in)
{
	power_management_unit *PMU = malloc(sizeof(power_management_unit));

	fread(&PMU->voltage, sizeof(float), 1, in);
	fread(&PMU->current, sizeof(float), 1, in);
	fread(&PMU->power_consumption, sizeof(float), 1, in);
	fread(&PMU->energy_regen, sizeof(int), 1, in);
	fread(&PMU->energy_storage, sizeof(int), 1, in);

	return PMU;
}

// functie care citeste si returneaza un vector cu operatiile ce trebuie
// aplicate unui senzor
int *operations_read(int nr_operations, FILE *in)
{
	int *v = (int *)malloc(nr_operations * sizeof(int));
	int i;
	for (i = 0; i < nr_operations; i++) {
		fread(&v[i], sizeof(int), 1, in);
	}
	return v;
}

// functie ce muta elementele din vector cu o pozitie la dreapta incepand
// de pe pozitia start pana la end
void right_move(void *data, int start, int end)
{
	sensor *sensor_vector = (sensor *)data;
	while (end > start) {
		sensor_vector[end] = sensor_vector[end - 1];
		end--;
	}
}

// functie ce cauta pozitia pe care trebuie introdus un senzor in vector la
// citirea acestuia
int find_sensor_position(void *data, int sensor_type, int vector_length)
{
	sensor *sensor_vector = (sensor *)data;
	// senzorii de tip TIRE sunt introdusi la final, iar cei de tip PMU sunt
	// introdusi inaintea celor de tip TIRE
	if (sensor_type == TIRE) {
		return vector_length;
	} else {
		int sensor_position = 0;
		// caut primul senzor de tip TIRE
		while (sensor_position < vector_length
			&& sensor_vector[sensor_position].sensor_type != TIRE) {
			sensor_position++;
		}
		// mut cu o pozitie la dreapta toti senzorii de tip TIRE
		right_move(sensor_vector, sensor_position, vector_length);
		// pozitia primului senzor TIRE devine pozitia la care trebuie introdus
		// senzorul PMU citit
		return sensor_position;
	}
}

void sensors_read(sensor **sensor_vector, int *sensor_number,
	void *(*data_read[2])(FILE *in), FILE *in)
{
	int i;
	fread(sensor_number, sizeof(int), 1, in);
	*sensor_vector = (sensor *)malloc(*sensor_number * sizeof(sensor));

	for (i = 0; i < *sensor_number; i++) {
		// citesc tipul de senzor
		int sensor_type;
		fread(&sensor_type, sizeof(int), 1, in);

		// aflu pozitia unde trebuie senzorul introdus in vector
		int sensor_position
			= find_sensor_position(*sensor_vector, sensor_type, i);

		(*sensor_vector)[sensor_position].sensor_type = sensor_type;
		(*sensor_vector)[sensor_position].sensor_data
			= data_read[(*sensor_vector)[sensor_position].sensor_type](in);
		fread(&(*sensor_vector)[sensor_position].nr_operations, sizeof(int), 1,
			in);
		(*sensor_vector)[sensor_position].operations_idxs = operations_read(
			(*sensor_vector)[sensor_position].nr_operations, in);
	}
}

// returneaza 1 daca senzorul e bun, 0 altfel
int TIRE_sensor_verify(void *data)
{
	tire_sensor *t = (tire_sensor *)data;
	if (t->pressure < 19 || t->pressure > 28) {
		return 0;
	}
	if (t->temperature < 0 || t->temperature > 120) {
		return 0;
	}
	if (t->wear_level < 0 || t->wear_level > 100) {
		return 0;
	}
	return 1;
}

// returneaza 1 daca senzorul e bun, 0 altfel
int PMU_sensor_verify(void *data)
{
	power_management_unit *p = (power_management_unit *)data;
	if (p->voltage < 10 || p->voltage > 20) {
		return 0;
	}
	if (p->current < -100 || p->current > 100) {
		return 0;
	}
	if (p->power_consumption < 0 || p->power_consumption > 1000) {
		return 0;
	}
	if (p->energy_regen < 0 || p->energy_regen > 100) {
		return 0;
	}
	if (p->energy_storage < 0 || p->energy_storage > 100) {
		return 0;
	}
	return 1;
}

void TIRE_data_print(void *data)
{
	tire_sensor *t = (tire_sensor *)data;
	printf("Tire Sensor\nPressure: %.2f\n", t->pressure);
	printf("Temperature: %.2f\n", t->temperature);
	printf("Wear Level: %d%%\n", t->wear_level);
	if (t->performace_score)
		printf("Performance Score: %d\n", t->performace_score);
	else
		printf("Performance Score: Not Calculated\n");
}

void PMU_data_print(void *data)
{
	power_management_unit *p = (power_management_unit *)data;
	printf("Power Management Unit\nVoltage: %.2f\n", p->voltage);
	printf("Current: %.2f\n", p->current);
	printf("Power Consumption: %.2f\n", p->power_consumption);
	printf("Energy Regen: %d%%\n", p->energy_regen);
	printf("Energy Storage: %d%%\n", p->energy_storage);
}

// functie ce citeste o comanda citita de la tastatura
void get_command(char s[SMAX])
{
	fgets(s, SMAX, stdin);
	if (s[strlen(s) - 1] == '\n') {
		s[strlen(s) - 1] = '\0';
	}
}

// functie ce returneaza pozitia senzorului dintr-o comanda daca aceasta
// este valida. Daca pozitia citita e invalida se returneaza -1
int get_number_if_valid(char *s, int sensor_number)
{
	char *number_string = strchr(s, ' ') + 1;
	int number;
	sscanf(number_string, "%d", &number);
	if (number < 0 || number >= sensor_number) {
		printf("Index not in range!\n");
		return -1;
	}
	return number;
}

void print_sensor(sensor sensor, void (*data_print[2])(void *))
{
	data_print[sensor.sensor_type](sensor.sensor_data);
}

void analyze_sensor(sensor sensor, void (*operations[8])(void *))
{
	// parcurg vectorul de operatii pentru senzor si aplic functiile
	// respective
	int i;
	for (i = 0; i < sensor.nr_operations; i++)
		operations[sensor.operations_idxs[i]](sensor.sensor_data);
}

// functie ce elibereaza memoria alocata unui senzor
void free_sensor(sensor s)
{
	free(s.sensor_data);
	free(s.operations_idxs);
}

// functie ce elibereaza memoria unui vector de senzori
void free_sensor_vector(void *data, int sensor_number)
{
	int i;
	sensor *sensor_vector = (sensor *)data;
	for (i = 0; i < sensor_number; i++) {
		free_sensor(sensor_vector[i]);
	}
	free(sensor_vector);
}

// functie ce construieste un vector nou de senzori ce va contine
// doar senzorii cu date valide
void clear_sensors(
	sensor **sensor_vector, int *sensor_number, int (*sensor_verify[2])(void *))
{
	sensor *new_sensor_vector = NULL;
	int new_senor_number = 0, i;
	for (i = 0; i < *sensor_number; i++) {
		int sensor_type = (*sensor_vector)[i].sensor_type;
		// daca senzorul are date valide il introduc noul vector de
		// senzori, altfel eliberez memoria alocata pentru datele si
		// operatiile senzorului
		if (sensor_verify[sensor_type]((*sensor_vector)[i].sensor_data)) {
			new_senor_number++;
			new_sensor_vector = (sensor *)realloc(
				new_sensor_vector, new_senor_number * sizeof(sensor));
			new_sensor_vector[new_senor_number - 1] = (*sensor_vector)[i];
		} else {
			free_sensor((*sensor_vector)[i]);
		}
	}
	// eliberez memoria alocata vechiului vechi de senzori
	free(*sensor_vector);
	// actualizez vectorul de senzori
	*sensor_vector = new_sensor_vector;
	*sensor_number = new_senor_number;
}

int main(int argc, char const *argv[])
{
	FILE *in = fopen(argv[1], "rb");

	// vector de pointeri la functii pentru citirea datelor unui senzor
	void *(*data_read[2])(FILE *in) = { TIRE_data_read, PMU_data_read };

	// vector de pointeri la functii pentru afisarea datelor unui senzor
	void (*data_print[2])(void *) = { TIRE_data_print, PMU_data_print };

	// vector de pointeri la functii pentru verificarea datelor unui senzor
	int (*sensor_verify[2])(void *) = { TIRE_sensor_verify, PMU_sensor_verify };

	void (*operations[8])(void *);
	get_operations((void **)operations);

	int sensor_number;
	sensor *sensor_vector = NULL;

	sensors_read(&sensor_vector, &sensor_number, data_read, in);
	// am terminat de citit din fisier deci pot sa-l inchid
	fclose(in);

	char command[SMAX];
	get_command(command);
	while (strcmp(command, "exit")) {
		if (strstr(command, "print")) {
			// extrag numarul din instructiune
			int number = get_number_if_valid(command, sensor_number);
			if (number >= 0) {
				print_sensor(sensor_vector[number], data_print);
			}
		} else if (strstr(command, "analyze")) {
			// extrag numarul din instructiune
			int number = get_number_if_valid(command, sensor_number);
			if (number >= 0) {
				analyze_sensor(sensor_vector[number], operations);
			}
		} else if (!strcmp(command, "clear")) {
			clear_sensors(&sensor_vector, &sensor_number, sensor_verify);
		}
		// citesc urmatoarea comanda
		get_command(command);
	}
	free_sensor_vector(sensor_vector, sensor_number);
	return 0;
}