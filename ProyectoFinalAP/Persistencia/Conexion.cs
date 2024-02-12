using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//-----------------------------//
using EntidadesCompartidas;

namespace Persistencia
{
   internal class Conexion ///cuando vayamos a entregar cambiar el servidor a "."
    {
        internal static string Cnn(Empleado pUsu = null) //pUsu=null significa que el parametro es opcional
        {
            if (pUsu == null)
                return @"Data Source =DESKTOP-94KPEUA\SQLEXPRESS; Initial Catalog = AgenciaViajes; Integrated Security = true";
            else
                return @"Data Source =DESKTOP-94KPEUA\SQLEXPRESS; Initial Catalog = AgenciaViajes; User=" + pUsu.UsuLog + "; Password='" + pUsu.UsuPass + "'";
        }
    }
}
    