import { ValidationError } from "runtypes";

export default abstract class Utils {
  static getValidationErrorMessage(error: any): string {
    const completeMessage = Object.values(error.details)[0] as string;
    const message = completeMessage.split(":")[1].trim();
    return message;
  }
}
