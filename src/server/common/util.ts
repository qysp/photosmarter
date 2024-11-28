import assert from 'node:assert';

export const clamp = (min: number, value: number, max: number) => {
  return Math.max(min, Math.min(value, max));
};

export const env = (
  name: string,
  defaultValue: string | undefined = undefined,
  assertMessage = `The environment variable '${name}' must be set!`,
): string => {
  const variable = process.env[name] ?? defaultValue;
  assert(variable !== undefined && variable !== '', assertMessage);
  return variable;
};
