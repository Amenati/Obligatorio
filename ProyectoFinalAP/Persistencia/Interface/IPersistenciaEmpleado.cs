using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EntidadesCompartidas;

namespace Persistencia
{
    public interface IPersistenciaEmpleado
    {
        Empleado BuscarEmpleado(string pUsulog, Empleado pLogueo);

        void Logueo(Empleado pEmp);//recibe usuario y contarsenia y devuelve obejto empleado
    }
}
