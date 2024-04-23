#include <Arduino_LSM9DS1.h>
//#include <Geometry.h>

#define MARGIN (0.005)
#define WINDOW_SIZE (25)

float dt;
//Pose Tracking;

class floatV3 {
  public:
    float x;
    float y;
    float z;

    floatV3() {
      x = y = z = 0;
    }

    floatV3(float i_x, float i_y, float i_z) {
      x = i_x;
      y = i_y;
      z = i_z;
    }

    void print() {
      Serial.print(x, 6);
      Serial.print('\t');
      Serial.print(y, 6);
      Serial.print('\t');
      Serial.println(z, 6);
    }

    float mag_2() {
      return x*x + y*y + z*z;
    }

    floatV3 operator+(floatV3 const& object) {
      floatV3 sum;
      sum.x = x + object.x;
      sum.y = y + object.y;
      sum.z = z + object.z;
      return sum;
    }

    floatV3 operator+=(floatV3 const& object) {
      *this = *this + object;
      return *this + object;
    }

    floatV3 operator-(floatV3 const& object) {
      floatV3 dif;
      dif.x = x - object.x;
      dif.y = y - object.y;
      dif.z = z - object.z;
      return dif;
    }

    floatV3 operator-() {
      floatV3 dif;
      dif.x = -x;
      dif.y = -y;
      dif.z = -z;
      return dif;
    }

    floatV3 operator-=(floatV3 const& object) {
      *this = *this - object;
      return *this - object;
    }

    floatV3 operator*(float const& object) {
      floatV3 prod;
      prod.x = x * object;
      prod.y = y * object;
      prod.z = z * object;
      return prod;
    }

    float dot(floatV3 const& object) {
      return x*(object.x) + y*(object.y) + z*(object.z);
    }

    floatV3 cross(floatV3 const& object) {
      floatV3 prod;
      prod.x = y*(object.z) - z*(object.y);
      prod.y = z*(object.x) - x*(object.z);
      prod.z = x*(object.y) - y*(object.x);
      return prod;
    }

    floatV3 rotation_deg(floatV3 orientation) {
      floatV3 rad = orientation * (3.1415926536/180);
      floatV3 ret;

      ret.x = x;
      ret.y = y*cos(rad.x) + z*sin(rad.x);
      ret.z = z*cos(rad.x) - y*sin(rad.x);

      ret.x = ret.x*cos(rad.y) - ret.z*sin(rad.y);
      //ret.y = ret.y;
      ret.z = ret.z*cos(rad.y) + ret.x*sin(rad.y);

      ret.x = ret.x*cos(rad.z) + ret.y*sin(rad.z);
      ret.y = ret.y*cos(rad.z) - ret.x*sin(rad.z);
      //ret.z = ret.z;
      
      return ret;
    }

} Location, Velocity, Orientation, Gravity;

class circularBuffer {
  private:
    floatV3 *buffer;
    size_t size;
    size_t next;
    size_t count;

  public:
    circularBuffer(const size_t input_size) {
      size = input_size;
      next = count = 0;
      buffer = new floatV3[size];
    }

    ~circularBuffer() {
      delete buffer;
    }

    size_t get_count() {
      return count;
    }

    size_t get_size() {
      return size;
    }

    void push(floatV3 object) {
      if (count < size) {
        count ++;
      }
      buffer[next] = object;
      next = (++next) % size;
    }

    void clear() {
      next = count = 0;
    }

    floatV3 avg() {
      floatV3 sum;
      if (count == size) {
        for (size_t i = 0; i < count; i++) {
          sum += buffer[i];
        }
      }else if (count <= next) {
        for (size_t i = next - count; i < next; i++) {
          sum += buffer[i];
        }
      }else {
        for (size_t i = 0; i < next; i++) {
          sum += buffer[i];
        }
        for (size_t i = size - count + next; i < size; i++) {
          sum += buffer[i];
        }
      }

      return sum * (1.0/count);
    }

    float var() {
      if (count != size) {
        Serial.println("Buffer not filled for variance calculation.");
        return -1;
      }
      float sum = 0;
      floatV3 avg = this->avg();
      for (size_t i = 0; i < size; i++) {
        sum += (buffer[i] - avg).mag_2();
      }
      return sum / size;
    }

} GravityData(WINDOW_SIZE);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
  IMU.setAccelFS(2);
  IMU.setAccelODR(3);
  IMU.setAccelOffset(-0.004921, -0.009977, -0.011418);
  //IMU.setAccelSlope(0.994238, 0.994899, 0.998787);

  IMU.setGyroFS(1);
  //IMU.setGyroODR(3);
  IMU.setGyroOffset (4.488003, 3.077322, 0.702270);
  IMU.setGyroSlope (1.158137, 1.160031, 1.197052);

  dt = 1.0 / IMU.getAccelODR();
  //Tracking = {.p = {0, 0, 0}};

  delay(500);
}

bool is_near(float a, float b, float margin) {
  return (a-b > -margin) && (a-b < margin);
}

void loop() {
  // put your main code here, to run repeatedly:
  floatV3 accel, gyro;
  while(!IMU.accelerationAvailable());
  IMU.readAcceleration(accel.x, accel.y, accel.z);
  while(!IMU.gyroscopeAvailable());
  IMU.readGyroscope(gyro.x, gyro.y, gyro.z);
  if (GravityData.get_count() == GravityData.get_size()) {
    if (is_near((accel-GravityData.avg()).mag_2(), 0, GravityData.var()) && \
        is_near(gyro.mag_2(), 0, MARGIN)) {
      GravityData.push(accel);
      Gravity = GravityData.avg();
    }else {
      /*
      Serial.print("Gravity:\t");
      Gravity.print();
      Serial.print("Magnitude^2:\t\t\t\t\t\t\t");
      Serial.println(Gravity.mag_2(), 6);
      */
      
      Orientation += gyro * dt;
      //Serial.print("Orientation:\t\t\t\t\t\t\t\t\t");
      //Orientation.print();

      accel -= Gravity.rotation_deg(Orientation);
      Velocity += accel * dt;
      Location += Velocity * dt;
    }
  }else {
    if (is_near(accel.mag_2(), 1.0, MARGIN)) {
      GravityData.push(accel);
      Gravity = GravityData.avg();
    }else {
      GravityData.clear();
      Serial.print("System not ready yet. Please keep sensor stationary.\tAccel Magnitude^2:\t");
      Serial.println(accel.mag_2(), 6);
    }
  }
}
