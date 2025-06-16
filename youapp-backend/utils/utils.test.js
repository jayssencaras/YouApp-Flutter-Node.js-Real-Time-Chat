const { calculateZodiac } = require('./utils');

describe('Zodiac Calculation', () => {
  test('should return Aries for 3/21', () => {
    expect(calculateZodiac(3, 21)).toBe('Aries');
  });

  test('should return Taurus for 4/25', () => {
    expect(calculateZodiac(4, 25)).toBe('Taurus');
  });

  test('should return Scorpio for 11/15', () => {
    expect(calculateZodiac(11, 15)).toBe('Scorpio');
  });

  test('should return Capricorn for 12/25', () => {
    expect(calculateZodiac(12, 25)).toBe('Capricorn');
  });

  test('should return Capricorn for 1/15', () => {
    expect(calculateZodiac(1, 15)).toBe('Capricorn');
  });

  test('should return Unknown for invalid date', () => {
    expect(calculateZodiac(13, 32)).toBe('Unknown');
  });
});
