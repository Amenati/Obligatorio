//------------------------------------------------------------------------------
// <auto-generated>
//     Este código se generó a partir de una plantilla.
//
//     Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//     Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ModeloEF
{
    using System;
    using System.Collections.Generic;
    
    public partial class Ventas
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Ventas()
        {
            this.Pasajeros = new HashSet<Pasajeros>();
        }
    
        public int NroVenta { get; set; }
        public System.DateTime FechaCompra { get; set; }
        public int Monto { get; set; }
        public string Usulog { get; set; }
        public string CodigoVuelo { get; set; }
        public string NumPasaporte { get; set; }
    
        public virtual Cliente Cliente { get; set; }
        public virtual Empleado Empleado { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Pasajeros> Pasajeros { get; set; }
        public virtual Vuelos Vuelos { get; set; }
    }
}
