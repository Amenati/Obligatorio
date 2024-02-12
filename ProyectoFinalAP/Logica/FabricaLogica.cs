using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
/*----------------------------*/
using EntidadesCompartidas;
using Logica;
using System.Xml;


namespace Logica
{
    public class FabricaLogica
    {
        public static Interface.ILogicaAeropuerto GetLogicaAeropuerto()
        {
            return Logica.LogicaAeropuerto.GetInstancia();
        }
        public static Interface.LogicaCiudad GetLogicaCiudad()
        {
            return Logica.LogicaCiudad.GetInstancia();
        }
        public static Interface.ILogicaCliente GetLogicaCliente()
        {
            return Logica.LogicaCliente.GetInstancia();
        }
        public static Interface.ILogicaEmpleado GetLogicaEmpleado()
        {
            return Logica.LogicaEmpleado.GetInstancia();
        }
        public static Interface.ILogicaVenta GetLogicaVenta()
        {
            return Logica.LogicaVenta.GetInstancia();
        }
        public static Interface.ILogicaVuelo GetLogicaVuelo()
        {
            return Logica.LogicaVuelo.GetInstancia();
        }
    }
}
