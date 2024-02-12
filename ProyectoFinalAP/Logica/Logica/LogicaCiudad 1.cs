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
    internal class LogicaCiudad : Interface.LogicaCiudad
    {
        private static LogicaCiudad instancia = null;
        private LogicaCiudad() { }
        public static LogicaCiudad GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaCiudad();
            return instancia;
        }


        /*--------------------------------------------------------------------------------------*/


        public Ciudad BuscarCiudadActivo(string pCodigoCiudad, Empleado pLogueo)
        {
            Ciudad ciu = null;

            ciu = FabricaPersistencia.GetPersistenciaCiudad().BuscarCiudadActivo(pCodigoCiudad, pLogueo);

            return ciu;
        }

        public void AgregarCiudad(Ciudad ciudad, Empleado pLogueo)
        {
            FabricaPersistencia.GetPersistenciaCiudad().AgregarCiudad(ciudad, pLogueo);
        }

        public void ModificarCiudad(Ciudad ciudad, Empleado pLogueo)
        {
            FabricaPersistencia.GetPersistenciaCiudad().ModificarCiudad(ciudad, pLogueo);
        }

        public void EliminarCiudad(Ciudad ciudad, Empleado pLogueo)
        {
            FabricaPersistencia.GetPersistenciaCiudad().EliminarCiudad(ciudad, pLogueo);
        }

        public List<Ciudad> ListarCiudades(Empleado pEmp)
        {
            return FabricaPersistencia.GetPersistenciaCiudad().ListarCiudades(pEmp);
        }


    }
}
