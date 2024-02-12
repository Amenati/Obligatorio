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
    internal class LogicaVuelo : Interface.ILogicaVuelo
    {
        private static LogicaVuelo instancia = null;
        private LogicaVuelo() { }
        public static LogicaVuelo GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaVuelo();
            return instancia;
        }


        /*--------------------------------------------------------------------------------------*/

        public void AltaVuelo(Vuelo unVuelo, Empleado pLogueo)
        {
            if (unVuelo.FechaPartida < DateTime.Now)
            {
                throw new Exception("La fecha de partida debe ser mayor a la fecha actual");
            }

            FabricaPersistencia.GetPersistenciaVuelo().AltaVuelo(unVuelo, pLogueo);
        }
        public List<Vuelo> ListarVuelos(Empleado pLogueo)
        {
            return FabricaPersistencia.GetPersistenciaVuelo().ListarVuelos(pLogueo);
        }

    }
}
