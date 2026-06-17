package poliwiki.model;

import java.io.Serializable;

public class Usuario implements Serializable {
    private int id;
    private String rol;
    private String nombres;
    private String apellidoPaterno;
    private String correoInstitucional;
    private String boleta;
    private String carrera; 

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }

    public String getApellidoPaterno() { return apellidoPaterno; }
    public void setApellidoPaterno(String apellidoPaterno) { this.apellidoPaterno = apellidoPaterno; }

    public String getCorreoInstitucional() { return correoInstitucional; }
    public void setCorreoInstitucional(String correoInstitucional) { this.correoInstitucional = correoInstitucional; }

    public String getBoleta() { return boleta; }
    public void setBoleta(String boleta) { this.boleta = boleta; }

    // <-- NUEVOS MÉTODOS PARA LA CARRERA
    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }

    public String getNombreCompleto() {
        return nombres + " " + apellidoPaterno;
    }
}