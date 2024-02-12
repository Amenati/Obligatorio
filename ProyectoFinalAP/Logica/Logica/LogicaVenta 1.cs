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
    internal class LogicaVenta : Interface.ILogicaVenta
    {
        private static LogicaVenta instancia = null;
        private LogicaVenta() { }
        public static LogicaVenta GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaVenta();
            return instancia;
        }


        /*--------------------------------------------------------------------------------------*/


        public void AltaVenta(Venta pVenta, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaVenta().AltaVenta(pVenta, pEmp);
        }
        public List<Venta> ListarVentasVuelo(Vuelo pVuelo, Empleado pEmp)
        {
            return FabricaPersistencia.GetPersistenciaVenta().ListarVentasVuelo(pVuelo, pEmp);
        }


    }
}
