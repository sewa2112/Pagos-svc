package cl.duoc.jv0101.caso06.pagos.service;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import cl.duoc.jv0101.caso06.pagos.model.Pago;
import cl.duoc.jv0101.caso06.pagos.repository.PagoRepository;

@Service
public class PagoService {

    private final PagoRepository repository;

    public PagoService(PagoRepository repository) {
        this.repository = repository;
    }

    public List<Pago> findAll() {
        return repository.findAll();
    }

    public Optional<Pago> findById(Long id) {
        return repository.findById(id);
    }

    public Pago create(Pago recurso) {
        return repository.save(recurso);
    }

    public Optional<Pago> update(Long id, Pago datos) {
        return repository.findById(id).map(existente -> {
            existente.setNombre(datos.getNombre());
            existente.setReserva(datos.getReserva());
            existente.setMonto(datos.getMonto());
            return repository.save(existente);
        });
    }

    public boolean delete(Long id) {
        return repository.findById(id).map(existente -> {
            repository.delete(existente);
            return true;
        }).orElse(false);
    }
}
