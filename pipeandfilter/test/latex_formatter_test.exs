defmodule LaTeXFormatterTest do
  use ExUnit.Case

  test "LaTeX code generation" do
    seller = "Sainsbury's, 15-17 Tottenham Ct Rd, London W1T 1BJ, UK"
    purchaser = "John Smith, 7 Horsefair Green, Otterbourne SO21 1GN, UK"
    bill = {[
      {{%Product{name: "Peas", price: 1.0}, 1}, 1.0},
      {{%Product{name: "Pizza", price: 2.8}, 3}, 8.399999999999999},
      {{%Product{name: "Ice Cream", price: 5.0}, 1}, 5.0},
      {{%Product{name: "Tomato Sauce", price: 1.2}, 2}, 2.4},
      {{%Product{name: "Rice", price: 1.0}, 2}, 2.0}
    ], 18.799999999999997}

    expected_code = "\\documentclass[a4paper, 10pt]{letter}\n\\address{Sainsbury's, \\\\ \n 15-17 Tottenham Ct Rd, \\\\ \n London W1T 1BJ, \\\\ \n UK}\n\\begin{document}\n\\begin{letter}\n{John Smith, \\\\ \n 7 Horsefair Green, \\\\ \n Otterbourne SO21 1GN, \\\\ \n UK}\n\\opening{}\n\\begin{center}\n\\begin{tabular}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \nRice & 2 & 1.00 & 2.00 \\\\ \\hline \nTomato Sauce & 2 & 1.20 & 2.40 \\\\ \\hline \nIce Cream & 1 & 5.00 & 5.00 \\\\ \\hline \nPizza & 3 & 2.80 & 8.40 \\\\ \\hline \nPeas & 1 & 1.00 & 1.00 \\\\ \\hline \n\\multicolumn{3}{|c|}{TOTAL} & 18.80 \\\\ \\hline\n\\end{tabular}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}"
    assert LaTeXFormatter.generate_latex(bill, seller, purchaser) == expected_code
  end
end
