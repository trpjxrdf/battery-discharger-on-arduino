#define PIN_CUR 6 // номер управляющего током вывода
#define PIN_V 20 // номер входа измерителя напряжения нагрузки
#define PIN_V0 10 // номер входа измерителя опорного напряжения
#define PIN_LED 17 // номер выхода для штатного светодиода

#define V0 1.265 // опорное напряжение
#define V_COEF 7.89 / 3.99 // коэффициент делителя напряжения нагрузки
#define V_FALL 0.04 // падение напряжения на открытом транзисторе
#define R 5.1 // сопротивление нагрузочного резистора
#define debug false

float current = 0.0; // требуемый ток нагрузки

void setup()
{
  TCCR0B = TCCR0B & 0b11111001; // устанавливаем максимальную частоту timer0 для ШИМ (*64). Параметр для deleay нужно будет умножать на 64.
  
  pinMode(PIN_CUR, OUTPUT);
  analogWrite(PIN_CUR, 0);

  pinMode(PIN_V, INPUT);
  pinMode(PIN_V0, INPUT);
 
  Serial.begin(115200);
  while (!Serial); // ждем подключения порта (только для Leonardo)
 
}

float lastV = -100;

int untilActive = 0;
boolean active = false;

char cmd[20];
int cmdPos = 0;

void loop()
{
  
  int n = 0;
  float s = 0;
  for(int i=0; i<100; i++) {
    float v1 = analogRead(PIN_V);
    float v0 = analogRead(PIN_V0);
    s += v1 / v0;
    n++;
    delay(10*64);
    
    while(Serial.available() > 0) {
      char c = Serial.read();
      if(c <= ' ') {
        if(cmdPos > 0) {
          cmd[cmdPos] = '\0';
          int i = atoi(cmd);
          current = 0.001 * i;
          cmdPos = 0;
          Serial.print("I=");
          Serial.println(current);
          untilActive = 0;
          active = true;
        }
      } else {
        if(cmdPos < 15) {
          cmd[cmdPos] = c;
          cmdPos++;
        }
      }  
    }
    
  }

  float v = V_COEF * V0 * s / n; // напряжение нагрузки

  boolean send = Serial ;//&& (abs(v - lastV) > 0.05);
  
  if(send) {
    Serial.print(v);
    Serial.print("\t");
  }
  
  if(debug) {
    active = true;
    untilActive = 0;
  } else if(v < 1.0) {
    // нет нагрузки
    active = false;
    untilActive = 0;
  } else if(v < 5.0) {
    // глубокий разряд
    if(active) {
      active = false;
      untilActive = 30;
    }  
  } else if(v > 7.0) {
    // запуск измерений
    active = true;
  }  

  if(send) lastV = v;
  
  if(active && untilActive == 0) {
    float max_current = (v - V_FALL) / R; // ток нагрузки при постоянно открытом транзисторе
    int x = (int)(current / max_current * 255.0);
    float real_current = current;
    if(x > 255) {      
      // нет возможности получить требуемый ток нагрузки
      real_current = max_current; 
      x = 255;
    }
    if(send) {
      Serial.print(real_current);  
      Serial.print("\t");
      Serial.print(x);
      Serial.println();
    }  
    analogWrite(PIN_CUR, x);
    digitalWrite(PIN_LED, false);
  } else {
    if(send) {
      Serial.print("0");  
      Serial.println();    
    }
    digitalWrite(PIN_LED, true);
    analogWrite(PIN_CUR, 0);
  }
  
  if(untilActive > 0) untilActive--;
 
}
