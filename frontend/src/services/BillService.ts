import Bill from "../entities/Bill";
import BillDto, { toBill } from "../entities/BillDto";
import BillRequestDto from "../entities/BillRequestDto";

export default abstract class BillService {
  private static endpoint = "/api";

  static generateBill(bill: BillRequestDto): Promise<number> {
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

  static getBill(id: number): Promise<Bill> {
    return fetch(`${this.endpoint}/bills/${id}`, {
      method: "GET",
    })
      .then((res) => res.json())
      .then((res) => toBill(res));
  }

  static getBills(user: BillRequestDto["user"]): Promise<Bill[]> {
    return fetch(
      `${this.endpoint}/bills?` + new URLSearchParams({ user }).toString(),
      {
        method: "GET",
      }
    )
      .then((res) => res.json())
      .then((res) => res.bills.map((bill: BillDto) => toBill(bill)));
  }
}
