using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using EntidadesCompartidas;

namespace Persistencia
{
    public interface IPersistenciaCiudad
    {
        void AgregarCiudad(Ciudad ciudad, Empleado pLogueo);
        Ciudad BuscarCiudadActivo(string codCiudad, Empleado pLogueo);
        void ModificarCiudad(Ciudad ciudad, Empleado pLogueo);
        void EliminarCiudad(Ciudad ciudad, Empleado pLogueo);
        List<Ciudad> ListarCiudades(Empleado pEmp);
    }
}
