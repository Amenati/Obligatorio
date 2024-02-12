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
    internal class LogicaCliente : Interface.ILogicaCliente
    {
        private static LogicaCliente instancia = null;
        private LogicaCliente() { }
        public static LogicaCliente GetInstancia()
        {
            if (instancia == null)
                instancia = new LogicaCliente();
            return instancia;
        }



        /*--------------------------------------------------------------------------------------*/


        public Cliente BuscarCliente(string pNumPasaporte, Empleado pEmp)
        {
            Cliente cli = null;

            cli = FabricaPersistencia.GetPersistenciaCliente().BuscarCliente(pNumPasaporte, pEmp);
           
            return cli;
        }

        public void AltaCliente(Cliente pCliente, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaCliente().AltaCliente(pCliente, pEmp);
        }

        public void ModificarCliente(Cliente pCliente, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaCliente().ModificarCliente(pCliente, pEmp);
        }

        public void EliminarCliente(Cliente pCliente, Empleado pEmp)
        {
            FabricaPersistencia.GetPersistenciaCliente().EliminarCliente(pCliente, pEmp);
        }

        public List<Cliente> ListarClientes(Empleado pEmp)
        {
            return FabricaPersistencia.GetPersistenciaCliente().ListarClientes(pEmp);
        }


    }
}
