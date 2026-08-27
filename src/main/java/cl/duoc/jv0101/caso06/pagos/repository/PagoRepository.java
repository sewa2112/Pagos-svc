package cl.duoc.jv0101.caso06.pagos.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import cl.duoc.jv0101.caso06.pagos.model.Pago;

public interface PagoRepository extends JpaRepository<Pago, Long> {
}
