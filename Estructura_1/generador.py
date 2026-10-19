from faker import Faker
import random

fake = Faker('es_CO') # Genera datos con formato de Colombia/Español

def generar_inserts():
    with open('inserts_masivos.sql', 'w', encoding='utf-8') as f:
        f.write("-- ==========================================\n")
        f.write("-- SCRIPT DE POBLACIÓN MASIVA (> 10,000 DATOS)\n")
        f.write("-- ==========================================\n\n")

        # 1. Base_Militar (50 registros)
        f.write("-- 1. Base_Militar\n")
        for i in range(1, 51):
            nombre = f"Base {fake.last_name()}"
            ubicacion = fake.city()
            f.write(f"INSERT INTO Base_Militar (id_base, nombre_base, ubicacion) VALUES ({i}, '{nombre}', '{ubicacion}');\n")
        
        # 2. Batallon (100 registros)
        f.write("\n-- 2. Batallon\n")
        for i in range(1, 101):
            nombre = f"Batallon de {fake.job()[:20]}"
            id_base = random.randint(1, 50)
            f.write(f"INSERT INTO Batallon (id_batallon, nombre_batallon, id_base) VALUES ({i}, '{nombre.replace(chr(39), '')}', {id_base});\n")

        # 3. Vehiculo (1000 registros)
        f.write("\n-- 3. Vehiculo\n")
        tipos_vehiculo = ['Tanque', 'Jeep', 'Camion de Transporte', 'Helicoptero', 'Ambulancia Militar']
        for i in range(1, 1001):
            placa = fake.unique.bothify(text='???-###').upper()
            tipo = random.choice(tipos_vehiculo)
            id_base = random.randint(1, 50)
            f.write(f"INSERT INTO Vehiculo (id_vehiculo, placa_identificacion, tipo_vehiculo, id_base) VALUES ({i}, '{placa}', '{tipo}', {id_base});\n")

        # 4. Rango (15 registros)
        f.write("\n-- 4. Rango\n")
        rangos = ['Soldado', 'Cabo', 'Sargento', 'Teniente', 'Capitan', 'Mayor', 'Coronel', 'General']
        for i in range(1, 16):
            rango = random.choice(rangos) + f" Nivel {i}"
            sueldo = round(random.uniform(1000.0, 5000.0), 2)
            f.write(f"INSERT INTO Rango (id_rango, nombre_rango, nivel_jerarquico, sueldo_base) VALUES ({i}, '{rango}', {i}, {sueldo});\n")

        # 5. Especialidad (50 registros)
        f.write("\n-- 5. Especialidad\n")
        for i in range(1, 51):
            espec = fake.job()[:40].replace(chr(39), '')
            riesgo = random.choice(['Bajo', 'Medio', 'Alto', 'Extremo'])
            bono = round(random.uniform(100.0, 1000.0), 2)
            f.write(f"INSERT INTO Especialidad (id_especialidad, nombre_especialidad, descripcion_rol, nivel_riesgo, bono_salarial) VALUES ({i}, 'Esp-{i}', '{espec}', '{riesgo}', {bono});\n")

        # 6. Historial_Medico (3000 registros)
        f.write("\n-- 6. Historial_Medico\n")
        sangre = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']
        for i in range(1, 3001):
            tipo_s = random.choice(sangre)
            alergias = f"'{fake.word()}'" if random.choice([True, False]) else 'NULL'
            estado = random.choice(['Optimo', 'Herido', 'En Recuperacion', 'Baja Medica'])
            f.write(f"INSERT INTO Historial_Medico (id_historial, tipo_sangre, alergias, estado_salud) VALUES ({i}, '{tipo_s}', {alergias}, '{estado}');\n")

        # 7. Soldado (3000 registros)
        f.write("\n-- 7. Soldado\n")
        for i in range(1, 3001):
            nombre = fake.name().replace(chr(39), '')
            f.write(f"INSERT INTO Soldado (id_soldado, nombres_apellidos, id_rango, id_especialidad, id_batallon, id_historial) VALUES ({i}, '{nombre}', {random.randint(1, 15)}, {random.randint(1, 50)}, {random.randint(1, 100)}, {i});\n")

        # 8. Categoria_Arma (20 registros)
        f.write("\n-- 8. Categoria_Arma\n")
        for i in range(1, 21):
            f.write(f"INSERT INTO Categoria_Arma (id_categoria, nombre_categoria, nivel_restriccion) VALUES ({i}, 'Categoria {i}', '{random.choice(['Estandar', 'Restringida', 'Clasificada'])}');\n")

        # 9. Armamento (2000 registros)
        f.write("\n-- 9. Armamento\n")
        for i in range(1, 2001):
            serie = fake.unique.bothify(text='WPN-########')
            estado = random.choice(['Operativa', 'En Mantenimiento', 'Dañada'])
            soldado = random.randint(1, 3000) if random.choice([True, False]) else 'NULL'
            f.write(f"INSERT INTO Armamento (id_arma, numero_serie, estado_arma, id_categoria, id_soldado) VALUES ({i}, '{serie}', '{estado}', {random.randint(1, 20)}, {soldado});\n")

        # 10. Calibre (30 registros)
        f.write("\n-- 10. Calibre\n")
        for i in range(1, 31):
            f.write(f"INSERT INTO Calibre (id_calibre, nombre_calibre, tipo_penetracion) VALUES ({i}, '{random.randint(5, 50)}mm', '{random.choice(['Ligera', 'Media', 'Perforante'])}');\n")

        # 11. Arma_Fuego (1000 registros - Hereda 1 a 1000 de Armamento)
        f.write("\n-- 11. Arma_Fuego\n")
        for i in range(1, 1001):
            capacidad = random.randint(5, 100)
            peso = round(random.uniform(1.0, 15.0), 2)
            modo = random.choice(['Semi', 'Auto', 'Rafaga'])
            f.write(f"INSERT INTO Arma_Fuego (id_arma, capacidad_cargador, peso_vacia_kg, modo_disparo, id_calibre) VALUES ({i}, {capacidad}, {peso}, '{modo}', {random.randint(1, 30)});\n")

        # 12. Explosivo (1000 registros - Hereda 1001 a 2000 de Armamento)
        f.write("\n-- 12. Explosivo\n")
        for i in range(1001, 2001):
            fecha = fake.date_between(start_date='today', end_date='+5y')
            peso = round(random.uniform(0.5, 50.0), 2)
            f.write(f"INSERT INTO Explosivo (id_arma, fecha_caducidad, peso_kg) VALUES ({i}, '{fecha}', {peso});\n")

        # 13. Municion (1500 registros)
        f.write("\n-- 13. Municion\n")
        for i in range(1, 1501):
            lote = fake.bothify(text='LT-####')
            fecha = fake.date_between(start_date='today', end_date='+10y')
            f.write(f"INSERT INTO Municion (id_municion, cantidad_disponible, fecha_vencimiento, lote, id_calibre, id_base) VALUES ({i}, {random.randint(100, 10000)}, '{fecha}', '{lote}', {random.randint(1, 30)}, {random.randint(1, 50)});\n")

        # 14. Mision (500 registros)
        f.write("\n-- 14. Mision\n")
        for i in range(1, 501):
            nombre = f"Operacion {fake.word().capitalize()}"
            fecha = fake.date_between(start_date='-2y', end_date='+1y')
            estado = random.choice(['Planificacion', 'En Progreso', 'Completada', 'Abortada'])
            f.write(f"INSERT INTO Mision (id_mision, nombre_mision, fecha_inicio, estado_mision) VALUES ({i}, '{nombre}', '{fecha}', '{estado}');\n")

        # 15. Asignacion_Mision (2000 registros)
        f.write("\n-- 15. Asignacion_Mision\n")
        for i in range(1, 2001):
            rol = random.choice(['Asalto', 'Francotirador', 'Medico', 'Ingeniero', 'Apoyo'])
            f.write(f"INSERT INTO Asignacion_Mision (id_asignacion, rol_asignado, id_mision, id_soldado) VALUES ({i}, '{rol}', {random.randint(1, 500)}, {random.randint(1, 3000)});\n")

    print("¡Archivo 'inserts_masivos.sql' generado con éxito con más de 12,000 registros!")

generar_inserts()