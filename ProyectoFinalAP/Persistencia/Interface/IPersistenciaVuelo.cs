using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using EntidadesCompartidas;

namespace Persistencia
{
    public interface IPersistenciaVuelo
    {
        void AltaVuelo(Vuelo unVuelo,Empleado pLogueo);

        List<Vuelo> ListarVuelos (Empleado pLogueo);

    }
}
