import BillDto from "../entities/BillDto";

export default abstract class BillService {
  private static endpoint = "/api";

  static generateBill(bill: BillDto): Promise<number> {
    return fetch(`${this.endpoint}/bills`, {
      method: "POST",
      body: JSON.stringify(bill),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((res) => res.id);
  }

  static isAvailable(id: number): Promise<boolean> {
    return fetch(`${this.endpoint}/bills/${id}/available`, {
      method: "GET",
    })
      .then((res) => res.json())
      .then((res) => res.available);
  }
}
