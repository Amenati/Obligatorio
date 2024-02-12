using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//---------------------------//
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia
{
    public interface IPersistenciaPasajero
    {
        void AgregarPasajero(int nroVenta,Pasajero pPasajero, SqlTransaction trn);

        List<Pasajero> ListarPasajerosVenta(Venta pVenta, Empleado pEmp);
    }
}
