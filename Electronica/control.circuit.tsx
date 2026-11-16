// Placa de control (capítulo 6). Solo esquemático: símbolos genéricos, sin huellas.
// Fuente: TFC/cap6/602, 603 y 605 (Tabla tab:pines_mega). Ver PLAN.md.

// ---- Terminales usadas del Arduino Mega 2560 Pro (Tabla tab:pines_mega) ----
const megaPins = {
  pin1: "V5",
  pin2: "GND",
  pin3: "A0",
  pin4: "A1",
  pin5: "A2",
  pin6: "D2",
  pin7: "D3",
  pin8: "D18",
  pin9: "D19",
  pin10: "D20_SDA",
  pin11: "D21_SCL",
  pin12: "D31",
  pin13: "D11",
  pin14: "D22",
  pin15: "D23",
  pin16: "D5",
  pin17: "D24",
  pin18: "D25",
  pin19: "D6",
  pin20: "D7",
  pin21: "D8",
  pin22: "D9",
  pin23: "D28",
  pin24: "D29",
  pin25: "D30",
  pin26: "D44",
  pin27: "D45",
} as const

const Microcontrolador = () => (
  <schematicsheet name="Microcontrolador" displayName="Microcontrolador" sheetIndex={0}>
    <chip
      name="U1"
      manufacturerPartNumber="Arduino Mega 2560 Pro"
      pinLabels={megaPins}
      schX={0}
      schY={0}
      schWidth={3.2}
      schPinArrangement={{
        leftSide: {
          direction: "top-to-bottom",
          pins: ["V5", "GND", "D20_SDA", "D21_SCL", "D31", "D2", "D3", "D18", "D19", "A0", "A1", "A2"],
        },
        rightSide: {
          direction: "top-to-bottom",
          pins: ["D11", "D22", "D23", "D5", "D24", "D25", "D6", "D7", "D8", "D9", "D28", "D29", "D30", "D44", "D45"],
        },
      }}
      connections={{
        V5: "net.V5",
        GND: "net.GND",
        D20_SDA: "net.I2C_SDA",
        D21_SCL: "net.I2C_SCL",
        D31: "net.BAT_ALCC",
        D2: "net.ENC_L_A",
        D3: "net.ENC_L_B",
        D18: "net.ENC_R_A",
        D19: "net.ENC_R_B",
        A0: "net.TEMP_NTC",
        A1: "net.M5_CS",
        A2: "net.M6_CS",
        D11: "net.M1_PUL",
        D22: "net.M1_DIR",
        D23: "net.M1_ENA",
        D5: "net.M2_PUL",
        D24: "net.M2_DIR",
        D25: "net.M2_ENA",
        D6: "net.M5_PWMA",
        D7: "net.M5_PWMB",
        D8: "net.M6_PWMA",
        D9: "net.M6_PWMB",
        D28: "net.M5_FLT",
        D29: "net.M6_FLT",
        D30: "net.TRAC_SLP",
        D44: "net.SERVO_M3",
        D45: "net.SERVO_M4",
      }}
    />

    {/* Conexión con la placa de potencia */}
    <chip
      name="J1"
      manufacturerPartNumber="Placa de potencia"
      pinLabels={{
        pin1: "V5",
        pin2: "V3_3",
        pin3: "V6_5",
        pin4: "GND",
        pin5: "SDA",
        pin6: "SCL",
        pin7: "ALCC",
      }}
      schX={-9}
      schY={0}
      schPinArrangement={{
        rightSide: {
          direction: "top-to-bottom",
          pins: ["V5", "V3_3", "V6_5", "GND", "SDA", "SCL", "ALCC"],
        },
      }}
      connections={{
        V5: "net.V5",
        V3_3: "net.V3_3",
        V6_5: "net.V6_5",
        GND: "net.GND",
        SDA: "net.I2C_SDA",
        SCL: "net.I2C_SCL",
        ALCC: "net.BAT_ALCC",
      }}
    />
  </schematicsheet>
)

// ---- Sensores (602) ----
const gy521Pins = {
  pin1: "VCC",
  pin2: "GND",
  pin3: "SCL",
  pin4: "SDA",
  pin5: "XDA",
  pin6: "XCL",
  pin7: "AD0",
  pin8: "INT",
} as const

const Mpu6050 = (props: { name: string; ad0: string; schX: number; schY: number }) => (
  <chip
    name={props.name}
    manufacturerPartNumber="MPU-6050 (modulo)"
    pinLabels={gy521Pins}
    schX={props.schX}
    schY={props.schY}
    schPinArrangement={{
      leftSide: { direction: "top-to-bottom", pins: ["VCC", "GND", "SCL", "SDA"] },
      rightSide: { direction: "top-to-bottom", pins: ["INT", "AD0", "XCL", "XDA"] },
    }}
    connections={{
      VCC: "net.V5",
      GND: "net.GND",
      SCL: "net.IMU_SCL",
      SDA: "net.IMU_SDA",
      AD0: props.ad0,
    }}
  />
)

const encoderPins = {
  pin1: "PHA",
  pin2: "PHB",
  pin3: "PHZ",
  pin4: "VCC",
  pin5: "GND",
} as const

const Encoder = (props: {
  name: string
  n: number
  netA: string
  netB: string
  schX: number
  schY: number
}) => (
  <>
    <chip
      name={props.name}
      manufacturerPartNumber="E6B2-CWZ6C"
      pinLabels={encoderPins}
      schX={props.schX}
      schY={props.schY}
      schPinArrangement={{
        leftSide: { direction: "top-to-bottom", pins: ["VCC", "GND"] },
        rightSide: { direction: "top-to-bottom", pins: ["PHA", "PHB", "PHZ"] },
      }}
      connections={{
        VCC: "net.V5",
        GND: "net.GND",
        PHA: props.netA,
        PHB: props.netB,
      }}
    />
    {/* Pull-up de 1 kΩ a 5.0 V por canal */}
    <resistor
      name={`R${props.n}`}
      resistance="1k"
      schX={props.schX + 4}
      schY={props.schY + 2}
      connections={{ pin1: "net.V5", pin2: props.netA }}
    />
    <resistor
      name={`R${props.n + 1}`}
      resistance="1k"
      schX={props.schX + 5.5}
      schY={props.schY + 2}
      connections={{ pin1: "net.V5", pin2: props.netB }}
    />
    {/* Filtro local de alimentación del encoder */}
    <capacitor
      name={`C${props.n}`}
      capacitance="47uF"
      polarized
      schX={props.schX - 4}
      schY={props.schY}
      connections={{ pin1: "net.V5", pin2: "net.GND" }}
    />
    <capacitor
      name={`C${props.n + 1}`}
      capacitance="100nF"
      schX={props.schX - 5.5}
      schY={props.schY}
      connections={{ pin1: "net.V5", pin2: "net.GND" }}
    />
  </>
)

const Sensores = () => (
  <schematicsheet name="Sensores" displayName="Sensores" sheetIndex={1}>
    {/* IMU principal, dirección 0x28, en el bus de 5.0 V */}
    <chip
      name="BNO1"
      manufacturerPartNumber="BNO055 (modulo)"
      pinLabels={{ pin1: "VCC", pin2: "GND", pin3: "SCL", pin4: "SDA" }}
      schX={-8}
      schY={8}
      schPinArrangement={{
        leftSide: { direction: "top-to-bottom", pins: ["VCC", "GND", "SCL", "SDA"] },
      }}
      connections={{
        VCC: "net.V5",
        GND: "net.GND",
        SCL: "net.I2C_SCL",
        SDA: "net.I2C_SDA",
      }}
    />

    {/* Traslador de nivel bidireccional de 4 canales: 5.0 V <-> 3.3 V */}
    <chip
      name="LLC1"
      manufacturerPartNumber="Traslador de nivel 4 canales"
      pinLabels={{
        pin1: "HV",
        pin2: "HV1",
        pin3: "HV2",
        pin4: "HV3",
        pin5: "HV4",
        pin6: "GND",
        pin7: "LV",
        pin8: "LV1",
        pin9: "LV2",
        pin10: "LV3",
        pin11: "LV4",
      }}
      schX={0}
      schY={8}
      schPinArrangement={{
        leftSide: { direction: "top-to-bottom", pins: ["HV", "HV1", "HV2", "HV3", "HV4", "GND"] },
        rightSide: { direction: "top-to-bottom", pins: ["LV", "LV1", "LV2", "LV3", "LV4"] },
      }}
      connections={{
        HV: "net.V5",
        LV: "net.V3_3",
        GND: "net.GND",
        HV1: "net.I2C_SCL",
        HV2: "net.I2C_SDA",
        LV1: "net.IMU_SCL",
        LV2: "net.IMU_SDA",
      }}
    />

    {/* IMU1: eje basculante (0x68, AD0 a tierra). IMU2: brazo de elevación (0x69, AD0 a 3.3 V) */}
    <Mpu6050 name="IMU1" ad0="net.GND" schX={8} schY={10} />
    <Mpu6050 name="IMU2" ad0="net.V3_3" schX={8} schY={6} />

    <Encoder name="ENC1" n={1} netA="net.ENC_L_A" netB="net.ENC_L_B" schX={-4} schY={0} />
    <Encoder name="ENC2" n={3} netA="net.ENC_R_A" netB="net.ENC_R_B" schX={-4} schY={-6} />

    {/* Termistor NTC 10 kΩ: divisor con 10 kΩ 1 % y filtro de 100 nF */}
    <resistor
      name="R5"
      resistance="10k"
      schX={10}
      schY={0}
      connections={{ pin1: "net.V5", pin2: "net.TEMP_NTC" }}
    />
    <chip
      name="TH1"
      manufacturerPartNumber="NTC 10k"
      pinLabels={{ pin1: "A", pin2: "B" }}
      schX={10}
      schY={-3}
      schPinArrangement={{
        topSide: { direction: "left-to-right", pins: ["A"] },
        bottomSide: { direction: "left-to-right", pins: ["B"] },
      }}
      connections={{ A: "net.TEMP_NTC", B: "net.GND" }}
    />
    <capacitor
      name="C5"
      capacitance="100nF"
      schX={12.5}
      schY={-3}
      connections={{ pin1: "net.TEMP_NTC", pin2: "net.GND" }}
    />
  </schematicsheet>
)

// ---- Señales de actuadores (603, 605) ----
const dm542Pins = {
  pin1: "ENA_N",
  pin2: "ENA_P",
  pin3: "DIR_N",
  pin4: "DIR_P",
  pin5: "PUL_N",
  pin6: "PUL_P",
} as const

// Entradas optoacopladas en cátodo común: los terminales negativos van a tierra
const Dm542 = (props: { name: string; m: string; schX: number; schY: number }) => (
  <chip
    name={props.name}
    manufacturerPartNumber="DM542 (senales)"
    pinLabels={dm542Pins}
    schX={props.schX}
    schY={props.schY}
    schPinArrangement={{
      leftSide: {
        direction: "top-to-bottom",
        pins: ["PUL_P", "PUL_N", "DIR_P", "DIR_N", "ENA_P", "ENA_N"],
      },
    }}
    connections={{
      PUL_P: `net.${props.m}_PUL`,
      DIR_P: `net.${props.m}_DIR`,
      ENA_P: `net.${props.m}_ENA`,
      PUL_N: "net.GND",
      DIR_N: "net.GND",
      ENA_N: "net.GND",
    }}
  />
)

const tractionPins = {
  pin1: "VCC",
  pin2: "GND",
  pin3: "PWMA",
  pin4: "PWMB",
  pin5: "CS",
  pin6: "FLT",
  pin7: "SLP",
} as const

const Traccion = (props: { name: string; m: string; schX: number; schY: number }) => (
  <chip
    name={props.name}
    manufacturerPartNumber="Controlador de traccion (senales)"
    pinLabels={tractionPins}
    schX={props.schX}
    schY={props.schY}
    schPinArrangement={{
      leftSide: {
        direction: "top-to-bottom",
        pins: ["VCC", "GND", "PWMA", "PWMB", "CS", "FLT", "SLP"],
      },
    }}
    connections={{
      VCC: "net.V5",
      GND: "net.GND",
      PWMA: `net.${props.m}_PWMA`,
      PWMB: `net.${props.m}_PWMB`,
      CS: `net.${props.m}_CS`,
      FLT: `net.${props.m}_FLT`,
      SLP: "net.TRAC_SLP",
    }}
  />
)

const Servo = (props: { name: string; net: string; schX: number; schY: number }) => (
  <chip
    name={props.name}
    manufacturerPartNumber="RDS3225"
    pinLabels={{ pin1: "PWM", pin2: "VCC", pin3: "GND" }}
    schX={props.schX}
    schY={props.schY}
    schPinArrangement={{
      leftSide: { direction: "top-to-bottom", pins: ["PWM", "VCC", "GND"] },
    }}
    connections={{ PWM: props.net, VCC: "net.V6_5", GND: "net.GND" }}
  />
)

const Actuadores = () => (
  <schematicsheet name="Actuadores" displayName="Senales de actuadores" sheetIndex={2}>
    <Dm542 name="U2" m="M1" schX={-8} schY={5} />
    <Dm542 name="U3" m="M2" schX={0} schY={5} />
    <Traccion name="U4" m="M5" schX={-8} schY={-2} />
    <Traccion name="U5" m="M6" schX={0} schY={-2} />
    <Servo name="M3" net="net.SERVO_M3" schX={8} schY={5} />
    <Servo name="M4" net="net.SERVO_M4" schX={8} schY={-2} />
  </schematicsheet>
)

export default () => (
  <board routingDisabled schTraceAutoLabelEnabled>
    <Microcontrolador />
    <Sensores />
    <Actuadores />
  </board>
)
