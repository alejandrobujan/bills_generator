import Input from "./Input";

interface Props {
  label?: string;
  placeholder?: string;
  value?: number;
  required?: boolean;
  onChange: (value: number) => void;
  ignoreEnter?: boolean;
}

export default function NumberInput(props: Props) {
  function onChange(value: string) {
    props.onChange(Number(value));
  }

  return <Input {...props} type="number" onChange={onChange} />;
}
