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
    public interface ILogicaEmpleado
    {
        Empleado BuscarEmpleado(string pUsulog, Empleado pLogueo);
        void Logueo(Empleado pEmp);
    }
}
