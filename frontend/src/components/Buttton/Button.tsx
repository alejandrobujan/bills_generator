import { ButtonProps } from "../../utils/defaultIntefaces";

const Button = ({ children, ...props }: ButtonProps) => {
  return <button {...props}>{children}</button>;
};

export default Button;
