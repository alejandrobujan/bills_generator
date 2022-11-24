import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  value?: number;
  required?: boolean;
  onChange: (value: number) => void;
}

export default function TextInput(props: Props) {
  function onChange(value: string) {
    props.onChange(Number(value));
  }

  return <Input {...props} type="text" onChange={onChange} />;
}
