defmodule BillsGenerator.Test.Utils do
  alias BillsGenerator.Repository.{Repo, BillDao}
  import Ecto.Query, only: [from: 2]

  def wait_until_bills_completed(n, sample_freq) do
    len = Repo.one(from(b in BillDao, select: count(b.pdf)))

    if len < n do
      Process.sleep(sample_freq)
      wait_until_bills_completed(n, sample_freq)
    end
  end

  def wait_until_error_bills_completed(n, sample_freq) do
    len = Repo.one(from(b in BillDao, select: count(b.error_msg)))

    if len < n do
      Process.sleep(sample_freq)
      wait_until_error_bills_completed(n, sample_freq)
    end
  end

  def restart_application() do
    Application.stop(:bills_generator)
    Application.start(:bills_generator)
  end
end
