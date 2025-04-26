import 'dart:math' as math;

class Complex {
  final double real;
  final double imaginary;

  Complex(this.real, this.imaginary);

  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  Complex operator +(Complex other) {
    return Complex(
      real + other.real,
      imaginary + other.imaginary,
    );
  }

  Complex operator -(Complex other) {
    return Complex(
      real - other.real,
      imaginary - other.imaginary,
    );
  }

  Complex conjugate() {
    return Complex(real, -imaginary);
  }

  double magnitude() {
    return math.sqrt(real * real + imaginary * imaginary);
  }

  Complex normalize() {
    final mag = magnitude();
    return Complex(real / mag, imaginary / mag);
  }

  @override
  String toString() {
    if (imaginary >= 0) {
      return '$real + ${imaginary}i';
    } else {
      return '$real - ${-imaginary}i';
    }
  }

  Map<String, dynamic> toJson() => {
        'real': real,
        'imaginary': imaginary,
      };

  factory Complex.fromJson(Map<String, dynamic> json) {
    return Complex(
      json['real'] as double,
      json['imaginary'] as double,
    );
  }
}
