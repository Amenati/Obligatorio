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
    
    public partial class Vuelos
    {
        public string CodigoVuelo { get; set; }
        public System.DateTime FechaPartida { get; set; }
        public System.DateTime FechaLlegada { get; set; }
        public int CantAsientos { get; set; }
        public int PrecioPasaje { get; set; }
        public string CodigoAeropOrigen { get; set; }
        public string CodigoAeropDestino { get; set; }
    
        public virtual AEROPUERTO AEROPUERTO { get; set; }
        public virtual AEROPUERTO AEROPUERTO1 { get; set; }
    }
}