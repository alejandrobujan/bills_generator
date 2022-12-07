import { ZodError } from "zod";

export default abstract class Utils {
  static getZodErrorMessages(error: ZodError): string[] {
    const messages: string[] = [];

    for (const errorItem of error.errors) {
      if (errorItem.path.length > 0) {
        messages.push(`${errorItem.path.join(".")}, ${errorItem.message}`);
      } else {
        messages.push(errorItem.message);
      }
    }

    return messages;
  }
}
