import BillDto from "../entities/BillDto";

export default abstract class BillService {
  private static endpoint = "/api";

  static generateBill(bill: BillDto): Promise<Blob> {
    return fetch(`${this.endpoint}/expenses`, {
      method: "POST",
      mode: "cors",
      body: JSON.stringify(bill),
      headers: {
        "Content-Type": "application/json",
      },
    }).then((res) => res.blob());
  }
}
