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
    internal class LogicaAeropuerto : Interface.ILogicaAeropuerto
    {
        private static LogicaAeropuerto instancia = null;
        private LogicaAeropuerto() { }
        public static LogicaAeropuerto GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaAeropuerto();
            return instancia;
        }


        /*--------------------------------------------------------------------------------------*/


        public Aeropuerto BuscarAeropuerto(string pCodigoAP, Empleado pEmp)
        {
            Aeropuerto ae = null;

            ae = FabricaPersistencia.GetPersistenciaAeropuerto().BuscarAeropuerto(pCodigoAP, pEmp);

            return ae;
        }

        public void AltaAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaAeropuerto().AltaAeropuerto(pAeropuerto, pEmp);
        }

        public void ModificarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaAeropuerto().ModificarAeropuerto(pAeropuerto, pEmp);
        }

        public void EliminarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaAeropuerto().EliminarAeropuerto(pAeropuerto, pEmp);
        }

        public List<Aeropuerto> ListarAeropuertos(Empleado pEmp)
        {
            return FabricaPersistencia.GetPersistenciaAeropuerto().ListarAeropuertos(pEmp);
        }


    }
}
