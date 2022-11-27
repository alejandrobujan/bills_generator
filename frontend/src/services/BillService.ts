import Bill from "../entities/Bill";
import BillDto from "../entities/BillDto";

export default abstract class BillService {
  private static endpoint = "/api";

  static generateBill(bill: BillDto): Promise<Bill["id"]> {
    return new Promise((resolve, reject) => {
      resolve("1");
    });
    // return fetch(`${this.endpoint}/expenses`, {
    //   method: "POST",
    //   mode: "cors",
    //   body: JSON.stringify(bill),
    //   headers: {
    //     "Content-Type": "application/json",
    //   },
    // }).then((res) => res.json());
  }

  static getBill(id: Bill["id"]): Promise<Blob | undefined> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve(undefined);
      }, 5000);
    });
    return fetch(`${this.endpoint}/expenses/${id}`, {
      method: "GET",
      mode: "cors",
    }).then((res) => res.blob());
  }
}
