import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  value?: string;
  required?: boolean;
  onChange: (value: string) => void;
  ignoreEnter?: boolean;
  className?: string;
}

export default function TextInput({ onChange, ...props }: Props) {
  return (
    <Input {...props} type="text" onChange={(e) => onChange(e.target.value)} />
  );
}
