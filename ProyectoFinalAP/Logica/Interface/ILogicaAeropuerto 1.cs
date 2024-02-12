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
    public interface ILogicaAeropuerto
    {
        Aeropuerto BuscarAeropuerto(string pCodigoAP, Empleado pEmp);
        void AltaAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp);
        void ModificarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp);
        void EliminarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp);
        List<Aeropuerto> ListarAeropuertos(Empleado pEmp);
    }
}
