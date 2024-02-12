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
    public interface ILogicaVenta
    {
        void AltaVenta(Venta pVenta, Empleado pEmp);
        List<Venta> ListarVentasVuelo(Vuelo pVuelo, Empleado pEmp);
    }
}
