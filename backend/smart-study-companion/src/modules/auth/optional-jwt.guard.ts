import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
    handleRequest(err, user, info) {

        // If there is an actual error
        if (err) {
            throw err;
        }

        // If token exists but is invalid
        if (info && info.name !== 'JsonWebTokenError' && info.message !== 'No auth token') {
            throw new UnauthorizedException(info.message);
        }

        // No token → allow request
        return user ?? null;
    }
}
