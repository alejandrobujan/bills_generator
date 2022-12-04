import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  value?: number;
  required?: boolean;
  onChange: (value: number) => void;
  ignoreEnter?: boolean;
}

export default function NumberInput({ onChange, ...props }: Props) {
  return (
    <Input
      {...props}
      type="number"
      onChange={(e) => onChange(Number(e.target.value))}
    />
  );
}
