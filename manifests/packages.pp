# Class to install build and runtime dependencies
class uwsgi::packages(
  Optional[Boolean] $manage_epel,
  Optional[Boolean] $install_pip,
  Optional[Boolean] $install_python_dev,
  Optional[String[1]] $python_pip,
  Optional[Variant[String[1],Array[String[1],1]]] $python_dev,
){
  if $manage_epel {
    include ::epel
  }

  if $install_python_dev {
    ensure_packages($python_dev)
  }
  if $install_pip {
    ensure_packages($python_pip)
    if $manage_epel {
      Class['epel'] -> Package[$python_pip]
    }
  }
}
