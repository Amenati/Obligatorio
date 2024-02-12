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
    public interface ILogicaVuelo
    {
        void AltaVuelo(Vuelo unVuelo, Empleado pLogueo);
        List<Vuelo> ListarVuelos(Empleado pLogueo);
    }
}
