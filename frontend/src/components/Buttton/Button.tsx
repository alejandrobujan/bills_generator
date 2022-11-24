interface Props {
  children: React.ReactNode;
  className?: string;
  type?: "button" | "submit" | "reset";
}

export default function Button({ children, className, type }: Props) {
  return <button type={type} className={className}>{children}</button>;
}
