import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  value?: string;
  required?: boolean;
  onChange: (value: string) => void;
  ignoreEnter?: boolean;
}

export default function TextInput(props: Props) {
  return <Input {...props} type="text" />;
}
