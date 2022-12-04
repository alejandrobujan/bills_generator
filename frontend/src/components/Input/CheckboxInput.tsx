import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  required?: boolean;
  checked?: boolean;
  onChange: (value: boolean) => void;
  ignoreEnter?: boolean;
}

export default function CheckboxInput({ onChange, ...props }: Props) {
  return (
    <Input
      {...props}
      type="checkbox"
      onChange={(e) => onChange(e.target.checked)}
    />
  );
}
