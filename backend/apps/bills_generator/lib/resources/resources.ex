defmodule Resources do
  def get_global_resources(locale \\ "en")
  def get_global_resources("es"), do: GlobalResourcesES.get_resources()
  def get_global_resources("gl"), do: GlobalResourcesGL.get_resources()
  def get_global_resources(_locale), do: GlobalResources.get_resources()


end
