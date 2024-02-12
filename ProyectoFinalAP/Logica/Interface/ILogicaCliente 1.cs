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
    public interface ILogicaCliente
    {
        Cliente BuscarCliente(string pNumPasaporte, Empleado pEmp);
        void AltaCliente(Cliente pCliente, Empleado pEmp);
        void ModificarCliente(Cliente pCliente, Empleado pEmp);
        void EliminarCliente(Cliente pCliente, Empleado pEmp);
        List<Cliente> ListarClientes(Empleado pEmp);
    }
}
