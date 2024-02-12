using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using EntidadesCompartidas;

namespace Persistencia
{
    public interface IPersistenciaVenta
    {
        void AltaVenta(Venta pVenta, Empleado pEmp);

        List<Venta> ListarVentasVuelo(Vuelo pVuelo, Empleado pEmp);


    }
}
