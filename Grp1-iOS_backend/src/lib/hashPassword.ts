import bcrypt from 'bcrypt';

export const hashPassword = async (password: string) => {
  const hash = await bcrypt.hash(password, 10);
  return hash;
};

export const comparePassword = async (
  enteredPassword: string,
  dbPassword: string,
) => {
  const comparison = await bcrypt.compare(enteredPassword, dbPassword);
  return comparison;
};
