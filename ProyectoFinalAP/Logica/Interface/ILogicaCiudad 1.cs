using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
/*----------------------------*/
using EntidadesCompartidas;
using System.Xml;

namespace Logica.Interface
{
    public interface LogicaCiudad
    {
        Ciudad BuscarCiudadActivo(string pCodigoCiudad, Empleado pLogueo);
        void AgregarCiudad(Ciudad ciudad, Empleado pLogueo);
        void ModificarCiudad(Ciudad ciudad, Empleado pLogueo);
        void EliminarCiudad(Ciudad ciudad, Empleado pLogueo);
        List<Ciudad> ListarCiudades(Empleado pEmp);
    }
}
