using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
/*----------------------------*/
using EntidadesCompartidas;
using Persistencia;
using System.Xml;

namespace Logica
{
    internal class LogicaEmpleado : Interface.ILogicaEmpleado
    {
        private static LogicaEmpleado instancia = null;
        private LogicaEmpleado() { }
        public static LogicaEmpleado GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaEmpleado();
            return instancia;
        }


        /*--------------------------------------------------------------------------------------*/


        public Empleado BuscarEmpleado(string pUsulog, Empleado pLogueo)
        {
            Empleado emp = null;

            emp = FabricaPersistencia.GetPersistenciaEmpleado().BuscarEmpleado(pUsulog, pLogueo);

            return emp;
        }

        public void Logueo(Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaEmpleado().Logueo(pEmp);
        }


    }
}
